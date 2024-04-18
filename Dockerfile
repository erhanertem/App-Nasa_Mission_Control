# Add a node.js image
FROM node:lts-alpine

# Folder where the dependency images will live @ - container root
WORKDIR /app

# COPY package.json @ APP-NASA-MISSION ROOT FOLDER TO Container ROOT <.> stands for </app>
# * captures both package and package-lock.json files
COPY package*.json ./

# Skips devDependencies from package.json files and stricyly acquires dependencies w/--only=production flag
# RUN npm install --only=production
# NOTE: In order to minimize the work to be done in case of re-creation of FE or BE side, we must break repopulation task into pieces of steps. Via making use of Docker layers, now only effected task gets executed and the remainder gets ignored.
COPY client/package*.json client/
RUN npm run install-client --omit=dev 
COPY server/package*.json server/
RUN npm run install-server --omit=dev 

# Copy client folder to the container
COPY client/ client/
# Populate client on the server side
RUN npm run build_mac --prefix client

# Copy server folder to the container
COPY server/ server/

# Minimize to USER privileges while running the command - node image we are usign already has a 'node' user w/minimized access comapred to a 'root' user
USER node

# Execute production app via array of strings as appears in npm script: run start script under server w/ pre-populated FE public folder 
CMD ["npm", "start", "--prefix", "server"]

# Determine a default port the container ships with
EXPOSE 8000