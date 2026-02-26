const fs = require('fs');
const { parseString, Builder } = require('xml2js');

const folderPath = '.'; // Use '.' to represent the current directory

fs.readdir(folderPath, (err, files) => {
    if (err) {
        console.error('Error reading folder:', err);
        return;
    }

    files.forEach(file => {
        if (file.endsWith('.xml')) {
            fs.readFile(file, 'utf-8', (err, data) => {
                if (err) {
                    console.error(`Error reading file ${file}:`, err);
                    return;
                }

                parseString(data, (err, result) => {
                    if (err) {
                        console.error(`Error parsing XML in file ${file}:`, err);
                        return;
                    }

                    // Check if the monster name contains a space and fix it
                    const monster = result.monster;
                    if (monster && monster.$.name.includes(' ')) {
                        const words = monster.$.name.split(' ');
                        const fixedName = words.map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ');
                        monster.$.name = fixedName;
                    }

                    // Convert the JSON back to XML and write it to the file
                    const builder = new Builder();
                    const xml = builder.buildObject(result);

                    fs.writeFile(file, xml, 'utf-8', err => {
                        if (err) {
                            console.error(`Error writing file ${file}:`, err);
                        } else {
                            console.log(`Fixed monster name in file ${file}`);
                        }
                    });
                });
            });
        }
    });
});