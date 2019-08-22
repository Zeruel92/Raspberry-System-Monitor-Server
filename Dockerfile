FROM balenalib/armv7hf-debian


WORKDIR /app

RUN [ "cross-build-start" ]
RUN curl -sf  -o dartsdk-linux-arm-release.zip -L https://storage.googleapis.com/dart-archive/channels/stable/release/2.4.1/sdk/dartsdk-linux-arm-release.zip
RUN apt-get update && apt-get install -y unzip
RUN unzip dartsdk-linux-arm-release.zip -d /app/
RUN rm dartsdk-linux-arm-release.zip

ENV PATH $PATH:dart-sdk/bin
EXPOSE 8888
EXPOSE 8889

ADD pubspec.yaml /app/
RUN pub get

ADD . /app
RUN pub get --offline
RUN ls
RUN [ "cross-build-end" ]
CMD []
ENTRYPOINT ["dart", "bin/main.dart"]