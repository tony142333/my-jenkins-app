# Use a lightweight web server as our base
FROM nginx:alpine

# Copy your local code (like an index.html) into the web server folder
# We will create index.html in the next step
COPY . /usr/share/nginx/html

# Tell the world our app runs on Port 80
EXPOSE 80