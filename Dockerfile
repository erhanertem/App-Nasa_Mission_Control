# Add a node.js image
# FROM erhanertem/nasa-project:latest
FROM node:lts-alpine

# NOTE: The WORKDIR command is used to define the working directory of a Docker container at any given time. If the WORKDIR command is not written in the Dockerfile, it will automatically be created by the Docker compiler. Hence, it can be said that the command performs mkdir and cd implicitly. WORKDIR can be reused to set a new working directory at any stage of the Dockerfile. The path of the new working directory must be given relative to the current working directory. While directories can be manually made and changed, it is strongly recommended that you use WORKDIR to specify the current directory in which you would like to work as​ it makes troubleshooting easier.
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