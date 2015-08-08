#make sure below dirs exist
# tmp/sockets
# tmp/pids
# logs

unicorn -c unicorn.rb -E development -D
