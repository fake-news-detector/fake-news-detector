const extractor = require("unfluff");
const axios = require("axios");

axios.get(process.argv[2], { timeout: 5000 }).then(res => {
  const text = extractor(res.data).text;
  const title = extractor(res.data).title;
  console.log(JSON.stringify({ title, text }));
});
