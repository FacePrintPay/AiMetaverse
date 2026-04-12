export default function handler(req, res) {
  res.status(200).json({
    ok: true,
    service: "sovereigngtp-terminal",
    timestamp: Date.now(),
    gamma_burst: "active"
  });
}
