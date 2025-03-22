ARG VERSION
FROM invoiceninja/invoiceninja:$VERSION
ARG GITHUB_TOKEN
RUN composer config --global github-oauth.github.com \$GITHUB_TOKEN
RUN composer require socialiteproviders/authelia
RUN rm -rf /var/lib/apt/lists/*
