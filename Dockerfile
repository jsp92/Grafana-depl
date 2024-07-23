FROM grafana/grafana
USER root
RUN apk update; \
    apk --no-cache add curl;
USER grafana
HEALTHCHECK CMD curl -f http://127.0.0.1:3000/api/health || exit 1
ENTRYPOINT ["/usr/bin/env"]
CMD [ "/run.sh" ]