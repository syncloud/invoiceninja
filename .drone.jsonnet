local name = 'invoiceninja';
local version = '5.11';
local nginx = '1.24.0';
local redis = '7.0.15';
local mariadb = '10.5.16-alpine';
local browser = 'firefox';
local platform = '25.02';
local selenium = '4.21.0-20240517';
local deployer = 'https://github.com/syncloud/store/releases/download/4/syncloud-release';
local python = '3.9-slim-buster';
local distro_default = 'buster';
local distros = ['bookworm', 'buster'];

local build(arch, test_ui, dind) = [{
  kind: 'pipeline',
  type: 'docker',
  name: arch,
  platform: {
    os: 'linux',
    arch: arch,
  },
  steps: [
           {
             name: 'version',
             image: 'debian:buster-slim',
             commands: [
               'echo $DRONE_BUILD_NUMBER > version',
             ],
           },
           {
             name: 'redis',
             image: 'redis:' + redis,
             commands: [
               './redis/build.sh',
             ],
           },
           {
             name: 'redis test',
             image: 'syncloud/platform-buster-' + arch + ':' + platform,
             commands: [
               './redis/test.sh',
             ],
           },
           {
             name: 'nginx',
             image: 'nginx:' + nginx,
             commands: [
               './nginx/build.sh',
             ],
           },
           {
             name: 'nginx test',
             image: 'syncloud/platform-buster-' + arch + ':' + platform,
             commands: [
               './nginx/test.sh',
             ],
           },
           {
             name: 'mariadb',
             image: 'linuxserver/mariadb:' + mariadb,
             commands: [
               './mariadb/build.sh',
             ],
           },
           {
             name: 'mariadb test',
             image: 'syncloud/platform-buster-' + arch + ':' + platform,
             commands: [
               './mariadb/test.sh',
             ],
           },
           {
             name: 'invoice ninja',
             image: 'docker:' + dind,
             commands: [
               './invoiceninja/build.sh ' + version,
             ],
             volumes: [
               {
                 name: 'dockersock',
                 path: '/var/run',
               },
             ],
           },
           {
             name: 'invoice ninja test',
             image: 'syncloud/platform-buster-' + arch + ':' + platform,
             commands: [
               './invoiceninja/test.sh',
             ],
           },
           {
             name: 'cli',
             image: 'golang:1.20',
             commands: [
               'cd cli',
               "go build -ldflags '-linkmode external -extldflags -static' -o ../build/snap/meta/hooks/install ./cmd/install",
               "go build -ldflags '-linkmode external -extldflags -static' -o ../build/snap/meta/hooks/configure ./cmd/configure",
               "go build -ldflags '-linkmode external -extldflags -static' -o ../build/snap/meta/hooks/pre-refresh ./cmd/pre-refresh",
               "go build -ldflags '-linkmode external -extldflags -static' -o ../build/snap/meta/hooks/post-refresh ./cmd/post-refresh",
               "go build -ldflags '-linkmode external -extldflags -static' -o ../build/snap/bin/cli ./cmd/cli",
             ],
           },


           {
             name: 'package',
             image: 'debian:buster-slim',
             commands: [
               'VERSION=$(cat version)',
               './package.sh ' + name + ' $VERSION ',
             ],
           },
         ] + [
           {
             name: 'test ' + distro,
             image: 'python:' + python,
             commands: [
               'APP_ARCHIVE_PATH=$(realpath $(cat package.name))',
               'cd test',
               './deps.sh',
               'py.test -x -s test.py --distro=' + distro + ' --domain=' + distro + '.com --app-archive-path=$APP_ARCHIVE_PATH --device-host=' + name + '.' + distro + '.com --app=' + name + ' --arch=' + arch,
             ],
           }
           for distro in distros
         ] + (if test_ui then ([
                                 {
                                   name: 'selenium',
                                   image: 'selenium/standalone-' + browser + ':' + selenium,
                                   detach: true,
                                   environment: {
                                     SE_NODE_SESSION_TIMEOUT: '999999',
                                     START_XVFB: 'true',
                                   },
                                   volumes: [{
                                     name: 'shm',
                                     path: '/dev/shm',
                                   }],
                                   commands: [
                                     'cat /etc/hosts',
                                     'DOMAIN="' + name + '.' + distro_default + '.com"',
                                     'getent hosts $DOMAIN | sed "s/$DOMAIN/auth.$DOMAIN.redirect/g" | sudo tee -a /etc/hosts',
                                     'cat /etc/hosts',
                                     '/opt/bin/entry_point.sh',
                                   ],
                                 },

                                 {
                                   name: 'selenium-video',
                                   image: 'selenium/video:ffmpeg-6.1.1-20240621',
                                   detach: true,
                                   environment: {
                                     DISPLAY_CONTAINER_NAME: 'selenium',
                                     FILE_NAME: 'video.mkv',
                                   },
                                   volumes: [
                                     {
                                       name: 'shm',
                                       path: '/dev/shm',
                                     },
                                     {
                                       name: 'videos',
                                       path: '/videos',
                                     },
                                   ],
                                 },
                                 {
                                   name: 'test-ui',
                                   image: 'python:' + python,
                                   commands: [
                                     'cd test',
                                     './deps.sh',
                                     'py.test -x -s ui.py --distro=buster --ui-mode=desktop --domain=' + distro_default + '.com --device-host=' + name + '.' + distro_default + '.com --app=' + name + ' --browser-height=2000 --browser=' + browser,
                                   ],
                                   volumes: [{
                                     name: 'videos',
                                     path: '/videos',
                                   }],
                                 },
                               ])
              else []) +
         (if arch == 'amd64' then [
            {
              name: 'test-upgrade',
              image: 'python:' + python,
              commands: [
                'APP_ARCHIVE_PATH=$(realpath $(cat package.name))',
                'cd test',
                './deps.sh',
                'py.test -x -s upgrade.py --distro=buster --ui-mode=desktop --domain=buster.com --app-archive-path=$APP_ARCHIVE_PATH --device-host=' + name + '.buster.com --app=' + name + ' --browser=' + browser,
              ],
              privileged: true,
              volumes: [{
                name: 'videos',
                path: '/videos',
              }],
            },
          ] else []) + [
    {
      name: 'upload',
      image: 'debian:buster-slim',
      environment: {
        AWS_ACCESS_KEY_ID: {
          from_secret: 'AWS_ACCESS_KEY_ID',
        },
        AWS_SECRET_ACCESS_KEY: {
          from_secret: 'AWS_SECRET_ACCESS_KEY',
        },
        SYNCLOUD_TOKEN: {
          from_secret: 'SYNCLOUD_TOKEN',
        },
      },
      commands: [
        'PACKAGE=$(cat package.name)',
        'apt update && apt install -y wget',
        'wget ' + deployer + '-' + arch + ' -O release --progress=dot:giga',
        'chmod +x release',
        './release publish -f $PACKAGE -b $DRONE_BRANCH',
      ],
      when: {
        branch: ['stable', 'master'],
        event: ['push'],
      },
    },
    {
      name: 'promote',
      image: 'debian:buster-slim',
      environment: {
        AWS_ACCESS_KEY_ID: {
          from_secret: 'AWS_ACCESS_KEY_ID',
        },
        AWS_SECRET_ACCESS_KEY: {
          from_secret: 'AWS_SECRET_ACCESS_KEY',
        },
        SYNCLOUD_TOKEN: {
          from_secret: 'SYNCLOUD_TOKEN',
        },
      },
      commands: [
        'apt update && apt install -y wget',
        'wget ' + deployer + '-' + arch + ' -O release --progress=dot:giga',
        'chmod +x release',
        './release promote -n ' + name + ' -a $(dpkg --print-architecture)',
      ],
      when: {
        branch: ['stable'],
        event: ['push'],
      },
    },
    {
      name: 'artifact',
      image: 'appleboy/drone-scp:1.6.4',
      settings: {
        host: {
          from_secret: 'artifact_host',
        },
        username: 'artifact',
        key: {
          from_secret: 'artifact_key',
        },
        timeout: '2m',
        command_timeout: '2m',
        target: '/home/artifact/repo/' + name + '/${DRONE_BUILD_NUMBER}-' + arch,
        source: 'artifact/*',
        strip_components: 1,
      },
      when: {
        status: ['failure', 'success'],
        event: ['push'],
      },
    },
  ],
  trigger: {
    event: [
      'push',
      'pull_request',
    ],
  },
  services: [
    {
      name: 'docker',
      image: 'docker:' + dind,
      privileged: true,
      volumes: [
        {
          name: 'dockersock',
          path: '/var/run',
        },
      ],
    },
  ] + [
    {
      name: name + '.' + distro + '.com',
      image: 'syncloud/platform-' + distro + '-' + arch + ':' + platform,
      privileged: true,
      volumes: [
        {
          name: 'dbus',
          path: '/var/run/dbus',
        },
        {
          name: 'dev',
          path: '/dev',
        },
      ],
    }
    for distro in distros
  ],
  volumes: [
    {
      name: 'dbus',
      host: {
        path: '/var/run/dbus',
      },
    },
    {
      name: 'dev',
      host: {
        path: '/dev',
      },
    },
    {
      name: 'shm',
      temp: {},
    },
    {
      name: 'videos',
      temp: {},
    },
    {
      name: 'dockersock',
      temp: {},
    },
  ],
}];

build('amd64', true, '20.10.21-dind') +
build('arm64', false, '20.10.21-dind')
