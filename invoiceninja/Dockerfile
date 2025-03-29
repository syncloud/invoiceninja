ARG VERSION
FROM invoiceninja/invoiceninja:$VERSION
ARG GITHUB_TOKEN
#RUN composer config --global github-oauth.github.com $GITHUB_TOKEN
#RUN sed -i "s/artisan key:generate/artisan key:generate --force/g" artisan composer.json
#RUN composer create-project --no-dev
#RUN sed -i 's/admin-api/einvoice/g' composer.json
#RUN composer require socialiteproviders/authelia
RUN rm -rf /var/lib/apt/lists/*



