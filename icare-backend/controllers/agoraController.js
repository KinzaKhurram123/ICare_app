const crypto = require('crypto');

const APP_ID = process.env.AGORA_APP_ID;
const APP_CERTIFICATE = process.env.AGORA_APP_CERTIFICATE;

// Agora Access Token V2 — implemented using Node.js built-in crypto only
// Reference: https://github.com/AgoraIO/Tools/tree/master/DynamicKey/AgoraDynamicKey

const VERSION = '007';
const PRIVILEGE_EXPIRE_SECONDS = 3600; // 1 hour

// Privileges for RTC token
const PRIVILEGE_JOIN_CHANNEL = 1;
const PRIVILEGE_PUBLISH_AUDIO = 2;
const PRIVILEGE_PUBLISH_VIDEO = 3;
const PRIVILEGE_PUBLISH_DATA = 4;

function packUint16(x) {
  const buf = Buffer.alloc(2);
  buf.writeUInt16LE(x, 0);
  return buf;
}

function packUint32(x) {
  const buf = Buffer.alloc(4);
  buf.writeUInt32LE(x >>> 0, 0);
  return buf;
}

function packInt32(x) {
  const buf = Buffer.alloc(4);
  buf.writeInt32LE(x, 0);
  return buf;
}

function packString(str) {
  const encoded = Buffer.from(str, 'utf8');
  return Buffer.concat([packUint16(encoded.length), encoded]);
}

function packMapUint32(map) {
  const keys = Object.keys(map).map(Number).sort((a, b) => a - b);
  const chunks = [packUint16(keys.length)];
  for (const k of keys) {
    chunks.push(packUint16(k), packUint32(map[k]));
  }
  return Buffer.concat(chunks);
}

function buildToken(channelName, uid, role, expireTimestamp) {
  if (!APP_ID || !APP_CERTIFICATE) {
    throw new Error('AGORA_APP_ID or AGORA_APP_CERTIFICATE not set in environment');
  }

  const uidStr = uid === 0 ? '' : String(uid);
  const issueTimestamp = Math.floor(Date.now() / 1000);
  const salt = Math.floor(Math.random() * 100000);

  const privileges = {
    [PRIVILEGE_JOIN_CHANNEL]: expireTimestamp,
    [PRIVILEGE_PUBLISH_AUDIO]: expireTimestamp,
    [PRIVILEGE_PUBLISH_VIDEO]: expireTimestamp,
    [PRIVILEGE_PUBLISH_DATA]: expireTimestamp,
  };

  // Message = salt + ts + privileges
  const message = Buffer.concat([
    packUint32(salt),
    packUint32(issueTimestamp),
    packMapUint32(privileges),
  ]);

  // Signing content = appId + channelName + uidStr + message
  const sigContent = Buffer.concat([
    packString(APP_ID),
    packString(channelName),
    packString(uidStr),
    message,
  ]);

  const signature = crypto
    .createHmac('sha256', APP_CERTIFICATE)
    .update(sigContent)
    .digest();

  // Token content = version + appId + message + signature
  const content = Buffer.concat([
    packString(APP_ID),
    message,
    packUint16(signature.length),
    signature,
  ]);

  const compressed = require('zlib').deflateRawSync(content);
  return VERSION + Buffer.from(compressed).toString('base64');
}

// GET /api/agora/token?channelName=xxx&uid=0
const getToken = (req, res) => {
  try {
    const { channelName, uid = 0 } = req.query;

    if (!channelName) {
      return res.status(400).json({ success: false, message: 'channelName is required' });
    }

    const uidNum = parseInt(uid, 10) || 0;
    const expireTimestamp = Math.floor(Date.now() / 1000) + PRIVILEGE_EXPIRE_SECONDS;
    const token = buildToken(channelName, uidNum, 1, expireTimestamp);

    return res.json({
      success: true,
      data: {
        token,
        appId: APP_ID,
        channelName,
        uid: uidNum,
        expiresAt: expireTimestamp,
      },
    });
  } catch (err) {
    console.error('Agora token error:', err);
    return res.status(500).json({ success: false, message: err.message });
  }
};

module.exports = { getToken };
