#!/bin/bash

useradd anandu
#su - anand -c "ssh-keygen -t rsa"
su - anandu -c "mkdir  ~anandu/.ssh && chmod 700 ~anandu/.ssh"
su - anandu -c "cat > ~anandu/.ssh/id_rsa << EOF
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAr3pKTEOLNuu5+0ZAeCvR2EuJLf0XyuCoKYoKA/IxdBYvCAFY
FVQYk1UgdEyJcQjiCUzw90jSxreEK1oGop4zmD+LyeC9+UycQy81hqYgZ0zG78kH
ToNmhOzfxPLSwzl7sboQ9S6fLudqxzo4euTCFrXb2qYxdVLYLZVZZWKn4aQO+Qqr
m2ZYUkSErdkQW2W5AErFakKcRUJQUBHuqGPYTOxRwocWt09574bXpWLY3HbppMm0
8PEiGcU3nkvMl6gVTUT+OsAGv7fPV6IyBK63V/iNAVoBNuEuvxcn0GGG0Sl5YK53
Gb9pXe1EtSSXkk+fOArESeVGzvbu//vJTcQOaQIDAQABAoIBAD39haHLerK8M8eA
2eWaFVfD14JXlsAk/UMvcLpUJQRNke/SCbv/KW9i80QihatY6AFBHR8+qrdovVhT
RWTNXoy6Zje7HWGkns9dLhuTNH9JsD2lVt91rBHpXGPHJI2zEO+IO9Vh0vpO5nnb
J3jCt44uUKy9aVt5GMWBrUMTxxr+tEILVOrgy5f2JBsWTE67tN5OBsz1NM9p8jQC
+MvsV4KJ6T11Lvq/i1xYuE2KIwJ+FOdJGEb6rJGD9xgEV+cgjikNT1f48PHkfs38
RiKsRKKBMQUk2yL9aTYXznxu2Ovvgx6eE2HRBoMmFN0A1TftJPP3DLEJcdFEM+sI
fOr4XwECgYEA2J9IIHsGyL1lWKhmMTrZTZ3Gz3hV4oH4PFhvAi5lCtuWAnost5bI
yKlQOmVeDYfxx3wlfA7vpkVuFEVsf/YObMyoT0O2M2IKUgeQ8dKfWBfUY9vcgjV1
SXoFkPQkG+UkZw8Svh+V6B1CENmxOaC9rgjUum9W5zsA9jJFEqEuAV0CgYEAz2BP
eE30dD1HPjrwlA7x7jF6LH274HTttYQNSV7evhAxjrbxrPi8aG35hrZZiCOAc6iT
PjCGT0nO0PKqDEiEXp8XjGhZ3uw2l9Kv5oKH8v2ORbywn0t0m0eIx/8fSE3DF3hX
Dm3+mURr9E9E0CK6IxAeJbeir/UFqQWo03k4tH0CgYEAvNt5dZ/s1TySTA5dMhR9
ebbRqvXd4uGvO2VaOsuaGjJBgZ1kuRbDrHY41QClVCSufV3WDGe1NgAYLaItKw6p
mt9+6cQ96GRUXRntm3cmpxX3fKwlfnv+6nVwvuSrSoqnBxbUH1/IQRqpC6nPYk+q
rz1RwczqNiRx/TLsl4ZgZp0CgYAlI5F38TYbbzIIIhQd4ANR7kh8GVSBYU+FF44t
mrD3hvzpGzhzCuTrKu7qQlQMfpctn34nQBd9sbE5WIw9wOr76zATdEjMFK++Rvw7
oxrn2KMXODDFhoTunkQP1U/r6glLdcDZk7dqCYfv7BZd1CpTxzou9RFMw+vsllfi
763JHQKBgCtP1rn/ShNEgoYkaJ1zQA2T4WwK8etBGUXoA2WmBl4EnMzdLG7xb7yE
ZavO+tXTgH4mQBv+lDplCvAKdyUHDvkg6FNrT6CswoHV7ZB/a37qyD61TWXVpcy5
T0TJx3WcdwTFEZrLAjJWsUZDSvtUCKToUqdrUOqQJcbtQmsxNmpG
-----END RSA PRIVATE KEY-----
EOF"

chown anandu:anandu ~anandu/.ssh/id_rsa

su - anandu -c "chmod 600 .ssh/id_rsa"


# Add github ssh keys (id_rsa and id_rsa.pub)
su - anandu -c "ssh -o 'StrictHostKeyChecking no' -T git@github.com"

su - anandu -c  'git config --global user.email "anandu@gmail.com"'
su - anandu -c 'git config --global user.name "Anand Ubale"'
su - anandu -c 'git config --global github.token e35f70184306333b211bb1986d7925b2'


su - anandu -c "git clone git://github.com/anandu/public_cookbook.git cookbook_public"
su - anandu -c "git clone git://github.com/opscode/cookbooks.git"
su - anandu -c "git clone git@github.com:anandu/cookbooks_premium.git"
su - anandu -c "git clone git@github.com:anandu/rightscale_tools.git"

su - anandu -c "/opt/rightscale/sandbox/bin/knife configure -i --defaults"
