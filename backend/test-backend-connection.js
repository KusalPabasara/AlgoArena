// Quick test to check if backend is accessible
const http = require('http');

const VPS_IP = '152.42.240.220';
const PORT = 5000;
const ENDPOINT = '/api/auth/login';

const testData = {
  email: 'superadmin@algoarena.com',
  password: 'AlgoArena@2024!'
};

const postData = JSON.stringify(testData);

const options = {
  hostname: VPS_IP,
  port: PORT,
  path: ENDPOINT,
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(postData)
  },
  timeout: 10000 // 10 seconds
};

console.log(`🔍 Testing backend connection to ${VPS_IP}:${PORT}${ENDPOINT}...\n`);

const req = http.request(options, (res) => {
  console.log(`✅ Connection successful!`);
  console.log(`Status Code: ${res.statusCode}`);
  console.log(`Headers:`, res.headers);
  
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    console.log(`\nResponse Body:`, data);
    if (res.statusCode === 200 || res.statusCode === 401) {
      console.log(`\n✅ Backend is accessible and responding!`);
    } else {
      console.log(`\n⚠️ Backend responded with status ${res.statusCode}`);
    }
    process.exit(0);
  });
});

req.on('error', (e) => {
  console.error(`❌ Connection error: ${e.message}`);
  if (e.code === 'ECONNREFUSED') {
    console.error(`\n⚠️ Backend server is not running or not accessible on ${VPS_IP}:${PORT}`);
    console.error(`Please check:`);
    console.error(`  1. Backend server is running on the VPS`);
    console.error(`  2. Port ${PORT} is open in firewall`);
    console.error(`  3. VPS IP address is correct`);
  } else if (e.code === 'ETIMEDOUT') {
    console.error(`\n⚠️ Connection timeout - backend is not responding`);
  }
  process.exit(1);
});

req.on('timeout', () => {
  console.error(`\n❌ Request timeout after 10 seconds`);
  console.error(`Backend is not responding in time`);
  req.destroy();
  process.exit(1);
});

req.write(postData);
req.end();

