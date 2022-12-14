module code.cloudfoundry.org/cli

go 1.19

require (
	code.cloudfoundry.org/bytefmt v0.0.0-20211005130812-5bb3c17173e5
	code.cloudfoundry.org/cfnetworking-cli-api v0.0.0-20190103195135-4b04f26287a6
	code.cloudfoundry.org/cli-plugin-repo v0.0.0-20221109154950-cfb32a0afe29
	code.cloudfoundry.org/cli/integration/assets/hydrabroker v0.0.0-20221205175650-5e857c5cb46c
	code.cloudfoundry.org/clock v1.0.0
	code.cloudfoundry.org/diego-ssh v0.0.0-20170109142818-18cdb3586e7f
	code.cloudfoundry.org/go-log-cache v1.0.1-0.20211011162012-ede82a99d3cc
	code.cloudfoundry.org/go-loggregator/v8 v8.0.5
	code.cloudfoundry.org/gofileutils v0.0.0-20170111115228-4d0c80011a0f
	code.cloudfoundry.org/jsonry v1.1.4
	code.cloudfoundry.org/lager v1.1.1-0.20191008172124-a9afc05ee5be
	code.cloudfoundry.org/tlsconfig v0.0.0-20220621140725-0e6fbd869921
	code.cloudfoundry.org/ykk v0.0.0-20170424192843-e4df4ce2fd4d
	github.com/SermoDigital/jose v0.9.2-0.20161205224733-f6df55f235c2
	github.com/blang/semver v3.5.1+incompatible
	github.com/cloudfoundry/bosh-cli v6.4.1+incompatible
	github.com/cloudfoundry/noaa v2.1.1-0.20190110210640-5ce49363dfa6+incompatible
	github.com/cloudfoundry/sonde-go v0.0.0-20220627221915-ff36de9c3435
	github.com/cyphar/filepath-securejoin v0.2.3
	github.com/docker/distribution v2.8.1+incompatible
	github.com/fatih/color v1.13.0
	github.com/google/go-querystring v1.1.0
	github.com/jessevdk/go-flags v1.5.0
	github.com/kr/pty v1.1.1
	github.com/lunixbochs/vtclean v1.0.0
	github.com/mattn/go-colorable v0.1.13
	github.com/mattn/go-runewidth v0.0.14
	github.com/moby/moby v20.10.21+incompatible
	github.com/nu7hatch/gouuid v0.0.0-20131221200532-179d4d0c4d8d
	github.com/onsi/ginkgo v1.16.4
	github.com/onsi/gomega v1.24.0
	github.com/pkg/errors v0.9.1
	github.com/sabhiram/go-gitignore v0.0.0-20171017070213-362f9845770f
	github.com/sajari/fuzzy v1.0.0
	github.com/sirupsen/logrus v1.9.0
	github.com/tedsuo/rata v1.0.1-0.20170830210128-07d200713958
	github.com/vito/go-interact v1.0.1
	golang.org/x/crypto v0.4.0
	golang.org/x/net v0.4.0
	golang.org/x/text v0.5.0
	gopkg.in/cheggaaa/pb.v1 v1.0.28
	gopkg.in/yaml.v2 v2.4.0
)

require (
	github.com/Azure/go-ansiterm v0.0.0-20210617225240-d185dfc1b5a1 // indirect
	github.com/bmatcuk/doublestar v1.3.4 // indirect
	github.com/bmizerany/pat v0.0.0-20210406213842-e4b6760bdd6f // indirect
	github.com/charlievieth/fs v0.0.3 // indirect
	github.com/cloudfoundry/bosh-utils v0.0.345 // indirect
	github.com/cppforlife/go-patch v0.2.0 // indirect
	github.com/elazarl/goproxy v0.0.0-20221015165544-a0805db90819 // indirect
	github.com/elazarl/goproxy/ext v0.0.0-20221015165544-a0805db90819 // indirect
	github.com/fsnotify/fsnotify v1.4.9 // indirect
	github.com/gogo/protobuf v1.3.2 // indirect
	github.com/golang/protobuf v1.5.2 // indirect
	github.com/google/go-cmp v0.5.9 // indirect
	github.com/gorilla/websocket v1.5.0 // indirect
	github.com/grpc-ecosystem/grpc-gateway/v2 v2.6.0 // indirect
	github.com/josharian/intern v1.0.0 // indirect
	github.com/mailru/easyjson v0.7.7 // indirect
	github.com/mattn/go-isatty v0.0.16 // indirect
	github.com/moby/term v0.0.0-20221205130635-1aeaba878587 // indirect
	github.com/nxadm/tail v1.4.8 // indirect
	github.com/opencontainers/go-digest v1.0.0 // indirect
	github.com/rivo/uniseg v0.4.3 // indirect
	github.com/rogpeppe/go-internal v1.9.0 // indirect
	github.com/tedsuo/ifrit v0.0.0-20220120221754-dd274de71113 // indirect
	golang.org/x/sys v0.3.0 // indirect
	golang.org/x/term v0.3.0 // indirect
	google.golang.org/genproto v0.0.0-20221207170731-23e4bf6bdc37 // indirect
	google.golang.org/grpc v1.51.0 // indirect
	google.golang.org/protobuf v1.28.1 // indirect
	gopkg.in/tomb.v1 v1.0.0-20141024135613-dd632973f1e7 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
)

replace (
	github.com/gogo/protobuf v1.2.1 => github.com/gogo/protobuf v1.3.2
	github.com/vito/go-interact => github.com/vito/go-interact v1.0.0
	gopkg.in/fsnotify.v1 v1.4.7 => github.com/fsnotify/fsnotify v1.4.7
)
