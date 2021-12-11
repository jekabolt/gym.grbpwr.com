FROM golang:1.17.1-alpine

ENV GO111MODULE=on

RUN apk add --no-cache git libgit2-dev alpine-sdk

WORKDIR /go/src/github.com/verless/

# buld verless 
RUN git clone https://github.com/verless/verless.git
RUN cd verless && \
    go build -v -o ./target/verless cmd/verless/main.go && \
    cp ./target/verless /bin/verless

RUN ls -la /bin/


# site
FROM alpine:latest

RUN apk add sassc

WORKDIR /go/src/github.com/jekabolt/gym.grbpwr.com

COPY --from=0 /bin/verless /bin/

RUN ls -la /bin/

COPY ./ ./

RUN verless build .

# ENTRYPOINT [ "verless" ] 
# ["verless serve -p 80 -w ."]

CMD ["verless", "serve", "-p", "80", "-w", "."]

EXPOSE 80