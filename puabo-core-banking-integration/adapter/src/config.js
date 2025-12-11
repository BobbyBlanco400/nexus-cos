export default {
  PORT: process.env.PORT || 8080,
  FINERACT_BASE: process.env.FINERACT_BASE || "http://fineract:8443/fineract-provider/api/v1",
  API_KEY: process.env.ADAPTER_API_KEY || "puabo-secret",
  MODE: process.env.BACKEND_MODE || "fineract", // fineract | dual | tm
};
