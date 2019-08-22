FROM balenalib/armv7hf-debian

RUN [ "cross-build-start" ]
WORKDIR /app

RUN wget https://storage.googleapis.com/dart-archive/channels/stable/release/2.4.1/sdk/dartsdk-linux-arm-release.zip
RUN unzip dartsdk-linux-arm-release.zip
ADD dart-sdk /app/dart-sdk
ENV PATH $PATH:dart-sdk/bin
RUN echo $PATH
ADD pubspec.* /app/
RUN ls
RUN pub get

ADD . /app
RUN pub get --offline
RUN [ "cross-build-end" ]
CMD []
ENTRYPOINT ["dart", "bin/main.dart"]