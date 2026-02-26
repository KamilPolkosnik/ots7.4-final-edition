const fs = require('fs');
const path = require('path');
const xml2js = require('xml2js');

const folderPath = './'; // Change this to the path of your folder

// Function to process a single XML file
function processFile(filePath) {
    fs.readFile(filePath, 'utf-8', (err, data) => {
        if (err) {
            console.error('Error reading file:', err);
            return;
        }

        // Parse XML to JSON
        xml2js.parseString(data, (err, result) => {
            if (err) {
                console.error(`Error parsing XML in file ${filePath}:`, err);
                return;
            }

            // Add <item id="6512" chance="250"/> after <item id="1987" chance="100000"/> as the last item
            if (result.monster && result.monster.loot && result.monster.loot[0] && result.monster.loot[0].item) {
                result.monster.loot[0].item.push({ $: { id: "6512", chance: "3000" } });
            }

            // Convert JSON back to XML
            const builder = new xml2js.Builder();
            const modifiedXml = builder.buildObject(result);

            // Write modified XML back to file
            fs.writeFile(filePath, modifiedXml, err => {
                if (err) {
                    console.error('Error writing file:', err);
                    return;
                }
                console.log(`Modified XML file saved as ${filePath}`);
            });
        });
    });
}

// Function to process all XML files in a folder and its subfolders
function processFolder(folderPath) {
    fs.readdir(folderPath, (err, files) => {
        if (err) {
            console.error('Error reading folder:', err);
            return;
        }

        files.forEach(file => {
            const filePath = path.join(folderPath, file);
            if (fs.statSync(filePath).isFile() && path.extname(filePath) === '.xml') {
                processFile(filePath);
            } else if (fs.statSync(filePath).isDirectory()) {
                processFolder(filePath); // Recursively process subdirectories
            }
        });
    });
}

// Start processing the folder
processFolder(folderPath);
