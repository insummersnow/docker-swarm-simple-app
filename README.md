기본 사용방법
======
1. ./devops.sh build
> 어플리케이션 빌드 & Docker 이미지 생성

2. ./devops.sh start
> 어플리케이션이 올라오기까지 20초가량 소요

3. ./devops.sh stop

4. ./devops.sh restart

*조회) docker ps || docker service ls || docker stack ps simple || docker stack ls*

배포시 사용방법
======
1. ".env" file의 version 변경
2. ./devops.sh build
3. ./devops.sh deploy
> 한번에 컨테이너 2개씩 배포
> 어플리케이션 올라오는 시간 감안하여 딜레이 30초
> start-first 방식으로 신규 컨테이너 올라온 후 구)컨테이너 Shutdown

scale in/out
======
1. ".env" file의 SCALE 변경
2. ./devops.sh scale
> 컨테이너 수를 줄이는 경우 최근에 뜬 컨테이너 순으로 Shutdown

요구사항 정리
======
1. build script는 gradle로 작성
> ./spring-boot/build.gradle 스크립트 작성
> gradle wrapper를 spring-boot 소스와 함께 이미지로 복사하여,
> 이미지 내에서 빌드 (Dockerfile 참고)

2. 어플리케이션들은 모두 독립적인 Container 로 구성
> nginx, spring-boot 컨테이너 독립적으로 구성

3. 어플리케이션들의 Log 는 Host 에 file 로 적재
> nginx access-log는 off 처리
> spring-boot 로그는 호스트의 ./logs 폴더에 떨어지도록 volume 바인딩
> spring-boot 로그 관련 설정은 application.preperties에 기재

4. Container scale in/out 가능해야 함
> docker service scale을 통해 처리
> docker embedded DNS이므로 동일 포트로 셋팅

5. 웹서버는 Nginx 사용
> docker-compose_start.yml에서 nginx 컨테이너 띄우도록 설정

6. 웹서버는 Reverse proxy 80 port, Round robin 방식으로 설정
> nginx 80 port : host 80 port 바인딩
> reverse-proxy 구성은 nginx-conf/reverse-proxy.conf 파일에 추가하였으며, 
> volume 바인딩을 통해 해당 설정이 nginx 이미지에 적용되도록 구성
> Round robin 방식은 docker embedded DNS를 통해 해결

7. 무중단 배포 동작을 구현 (배포 방식에 제한 없음)
> Docker Swarm 사용하여 Stack으로 컨테이너 구성 후 서비스 이미지 Update 하는 방식으로 구현

8. 실행스크립트 개발언어는 bash/python/go 선택하여 작성
> devops.sh bash script 작성

9. 어플리케이션 REST API 추가, GET /health로 호출되도록 처리
> actuator 사용
> application.properties actuator endpoint path 추가