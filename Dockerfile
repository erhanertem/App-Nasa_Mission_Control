# Add a node.js image
FROM node:lts-alpine

# Folder where the dependency images will live @
WORKDIR /app

# COPY FROM APP-NASA-MISSION FOLDER TO WORKDIR APP FOLDER
COPY . .

# Skips devDependencies from package.json files and stricyly acquires dependencies w/--only=production flag
RUN npm install --only=production

# Populate client on the server side
RUN npm run buil_mac --prefix client

# Minimize to USER privileges while running the command - node image we are usign already has a 'node' user w/minimized access comapred to a 'root' user
USER node

# Execute production app via array of strings as appears in npm script: run start script under server w/ pre-populated FE public folder 
CMD ["npm", "start", "--prefix", "server"]

# Determine a default port the container ships with
EXPOSE 8000