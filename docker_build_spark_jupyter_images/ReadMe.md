# Build hetzner-base-lxb first then build the other two
docker build . -t hetzner-base-lxb -f hetzner-base-lxb.Dockerfile  

docker build . -t jupyterlab-lxb -f jupyterlab-lxb.Dockerfile  
docker build . -t spark-cluster-lxb -f spark-cluster-lxb.Dockerfile