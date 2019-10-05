ARG BASE_IMAGE=getwarped/warp0-debian10-python37:latest

FROM $BASE_IMAGE

COPY --chown=1001:0 . /opt/app-root/

RUN assemble-image

CMD [ "start-container" ]

EXPOSE 8080
