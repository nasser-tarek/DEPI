FROM alpine
RUN apk add curl
RUN echo "hello from container">/startup.txt
CMD [ "cat","/startup.txt" ]