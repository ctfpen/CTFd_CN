FROM python:3.7-slim-buster
WORKDIR /opt/CTFd
RUN mkdir -p /opt/CTFd /var/log/CTFd /var/uploads

# hadolint ignore=DL3008

# 添加 tuna debian mirror
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak
RUN echo deb http://mirrors.tuna.tsinghua.edu.cn/debian/ buster main contrib non-free > /etc/apt/sources.list
RUN echo deb http://mirrors.tuna.tsinghua.edu.cn/debian/ buster-updates main contrib non-free >> /etc/apt/sources.list
RUN echo deb http://mirrors.tuna.tsinghua.edu.cn/debian/ buster-backports main contrib non-free >> /etc/apt/sources.list
RUN echo deb http://mirrors.tuna.tsinghua.edu.cn/debian-security buster/updates main contrib non-free >> /etc/apt/sources.list

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        python3-dev \
        libffi-dev \
        libssl-dev \
        git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /opt/CTFd/

# 添加 tuna pip mirror
#RUN pip install -r requirements.txt --no-cache-dir
RUN pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir -r requirements.txt

COPY . /opt/CTFd

# hadolint ignore=SC2086
RUN for d in CTFd/plugins/*; do \
        if [ -f "$d/requirements.txt" ]; then \
            pip install -r $d/requirements.txt --no-cache-dir; \
        fi; \
    done;

RUN adduser \
    --disabled-login \
    -u 1001 \
    --gecos "" \
    --shell /bin/bash \
    ctfd
RUN chmod +x /opt/CTFd/docker-entrypoint.sh \
    && chown -R 1001:1001 /opt/CTFd /var/log/CTFd /var/uploads

USER 1001
EXPOSE 8000
ENTRYPOINT ["/opt/CTFd/docker-entrypoint.sh"]
