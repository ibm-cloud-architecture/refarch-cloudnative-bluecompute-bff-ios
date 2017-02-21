FROM ibmcom/swift-ubuntu:latest
LABEL Description="Docker image for building and running the refarch-cloudnative-bluecompute-bff-ios sample application."

# Expose default port for Kitura
EXPOSE 8090

RUN mkdir /root/refarch-cloudnative-bluecompute-bff-ios

ADD Sources /root/refarch-cloudnative-bluecompute-bff-ios
ADD Package.swift /root/refarch-cloudnative-bluecompute-bff-ios
#ADD LICENSE /root/refarch-cloudnative-bluecompute-bff-ios
#ADD .swift-version /root/refarch-cloudnative-bluecompute-bff-ios

RUN cd /root/refarch-cloudnative-bluecompute-bff-ios && swift build

USER root
#CMD ["/root/refarch-cloudnative-bluecompute-bff-ios/.build/debug/refarch-cloudnative-bluecompute-bff-ios"]
CMD [ "sh", "-c", "cd /root/refarch-cloudnative-bluecompute-bff-ios && .build/debug/refarch-cloudnative-bluecompute-bff-ios" ]