FROM golang

# Get Dependencies
RUN go get -v github.com/hashicorp/consul/api                 \
 && go get -v github.com/docopt/docopt-go

# Build consul-backup
RUN git clone https://github.com/kailunshi/consul-backup.git  \
 && cd consul-backup && go build && cp consul-backup /bin/

# Initialize
RUN mkdir -p /backup

WORKDIR /backup
