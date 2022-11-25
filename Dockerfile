FROM alpine:latest
RUN echo "This is build time"
# Pour les plus téméraires (!) changer la valeur de la variable user
ENV user "SFIL USER"
RUN touch /a_new_file
CMD echo "This is runtime: hello from $user"
