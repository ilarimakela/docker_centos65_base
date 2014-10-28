[ -d .tmp ] || mkdir .tmp
    
tmpdir=$( mktemp -d )
trap "echo removing ${tmpdir}; rm -rf ${tmpdir}" EXIT

febootstrap \
    -u http://mirrors.mit.edu/centos/6.5/updates/x86_64/ \
    -i centos-release \
    -i yum \
    -i iputils \
    -i tar \
    -i which \
    -i http://mirror.pnl.gov/epel/6/i386/epel-release-6-8.noarch.rpm \
    centos65 \
    ${tmpdir} \
    http://mirrors.mit.edu/centos/6.5/os/x86_64/

febootstrap-run ${tmpdir} -- sh -c 'echo "NETWORKING=yes" > /etc/sysconfig/network'

## set timezone of container to UTC
febootstrap-run ${tmpdir} -- ln -f /usr/share/zoneinfo/Etc/UTC /etc/localtime

febootstrap-run ${tmpdir} -- yum clean all

[ -d dist ] || mkdir dist

## xz gives the smallest size by far, compared to bzip2 and gzip, by like 50%!
febootstrap-run ${tmpdir} -- tar -cf - . | xz > dist/centos65.tar.xz
