#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Get environment variables with fallbacks
const APP_NAME = process.env.NEXT_PUBLIC_APP_NAME || 'Documenso';
const APP_SHORT_NAME = process.env.NEXT_PUBLIC_APP_SHORT_NAME || 'Documenso';

// Function to process a file and replace template variables
function processFile(filePath) {
  try {
    let content = fs.readFileSync(filePath, 'utf8');
    
    // Replace template variables
    content = content.replace(/\{\{APP_NAME\}\}/g, APP_NAME);
    content = content.replace(/\{\{APP_SHORT_NAME\}\}/g, APP_SHORT_NAME);
    
    fs.writeFileSync(filePath, content, 'utf8');
    console.log(`✅ Processed: ${filePath}`);
  } catch (error) {
    console.error(`❌ Error processing ${filePath}:`, error.message);
  }
}

// Process webmanifest files
const webmanifestFiles = [
  'apps/remix/public/site.webmanifest',
  'packages/assets/site.webmanifest'
];

console.log('🔄 Processing branding files...');
console.log(`📝 Using APP_NAME: ${APP_NAME}`);
console.log(`📝 Using APP_SHORT_NAME: ${APP_SHORT_NAME}`);

webmanifestFiles.forEach(file => {
  const filePath = path.join(process.cwd(), file);
  if (fs.existsSync(filePath)) {
    processFile(filePath);
  } else {
    console.warn(`⚠️  File not found: ${filePath}`);
  }
});

console.log('✅ Branding processing complete!'); 