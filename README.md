# Containerized Streamsets Syslog Listener to MapR Streams
---------------
Note this Container is a Proof of Concept, and should be tweaked for production use. 


## Building

- Copy the file env.list.template to env.list
- Edit the env.list to reflect your environment. Don't change below the line where it says do not change
- run ./build.sh to build the container


## Running

- Prior to running, run the mkstream.sh - This assumes you are running on node that maprcli on it. If you are not, copy this to that node and make a volume and stream for the testing
- Run ./run.sh - This, if the Streamsets config is not created, creates these locations, and copies files from the container for editing. 
- Once the container is up and runnning run /app/sbin/start.sh inside the container to start Streamsets. 

## Connecting
- The default username is admin/admin
- Connect to the node on whatever port you set for: STREAMSETS_TCP_PORT
- To demonstrate a UDP listener, import the file: UDPListener6f6f4178-1f70-4d28-b034-22cdcab5ae23.json
  - If you didn't change the default stream path and topic this stream will work. If you did change the path location and topic, make sure you go to the MapR Streams configuration and update the location of the stream
- Run the Pipeline
  - To test the Pipeline you can run the send_msg.sh to send a json-ish Syslog message to watch the data come in. 

## Productionalizing

This container is Proof of concept and should be review before deploying in your environment depending on the workload. Here are some things to consider:

- Changing authentication admin/admin is not acceptable
- Using a trusted, or enterprise trusted certificate for HTTPS
- Setting up Error conditions in streamsets to know how to handle record errors
- Setting up Alerting etc in Streamsets
- Doing performance testing for your workload and adjusting Java Heap size to address issues if they occur. 
- ???
- Profit
