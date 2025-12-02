const certificateService = require('../services/certificateService');

exports.issueCertificate = async (req, res, next) => {
  try {
    const { recipient, cid, dataHash, metadata } = req.body;
    if (!recipient || !cid || !dataHash) {
      return res.status(400).json({ error: 'recipient, cid and dataHash are required' });
    }
    const result = await certificateService.issueCertificate({ recipient, cid, dataHash, metadata });
    res.json(result);
  } catch (err) {
    next(err);
  }
};

exports.revokeCertificate = async (req, res, next) => {
  try {
    const { certificateId } = req.body;
    if (!certificateId) return res.status(400).json({ error: 'certificateId is required' });
    const result = await certificateService.revokeCertificate(certificateId);
    res.json(result);
  } catch (err) {
    next(err);
  }
};

exports.getCertificatesByIssuer = async (req, res, next) => {
  try {
    const { issuer } = req.params;
    const list = await certificateService.certificatesOfIssuer(issuer);
    res.json({ certificates: list.map((id) => id.toString()) });
  } catch (err) {
    next(err);
  }
};

exports.getCertificatesByRecipient = async (req, res, next) => {
  try {
    const { recipient } = req.params;
    const list = await certificateService.certificatesOfRecipient(recipient);
    res.json({ certificates: list.map((id) => id.toString()) });
  } catch (err) {
    next(err);
  }
};

exports.exists = async (req, res, next) => {
  try {
    const { id } = req.params;
    const exists = await certificateService.exists(id);
    res.json({ exists });
  } catch (err) {
    next(err);
  }
};
