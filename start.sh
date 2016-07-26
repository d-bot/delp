#make sure below dirs exist
# tmp/sockets
# tmp/pids
# logs

unicorn -c u-delp.rb -E development -D
