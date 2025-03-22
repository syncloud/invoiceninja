ARG VERSION
FROM invoiceninja/invoiceninja:$VERSION
RUN  --mount=type=secret,id=gh,env=GITHUB_TOKEN composer config --global github-oauth.github.com \$GITHUB_TOKEN
RUN composer require socialiteproviders/authelia
RUN rm -rf /var/lib/apt/lists/*
