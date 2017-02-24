FROM ibmcom/swift-ubuntu:latest
LABEL Description="Docker image for building and running the bluecompute-bff-ios sample application."

# Expose default port for Kitura
EXPOSE 8090

RUN mkdir /root/bluecompute-bff-ios

ADD Sources /root/bluecompute-bff-ios
ADD Package.swift /root/bluecompute-bff-ios
ADD .swift-version /root/bluecompute-bff-ios

RUN cd /root/bluecompute-bff-ios && swift build

USER root
CMD [ "/root/bluecompute-bff-ios/.build/debug/bluecompute-bff-ios" ]