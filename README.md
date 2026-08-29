# ZMK Config for Charybdis 4x6 (XI-MK1_2)

무선 스플릿 트랙볼 키보드 **Charybdis 4x6 (XI-MK1_2)** 용 개인 ZMK 설정.

- 하드웨어 정의(핀맵, 왼손 엔코더 2개, WS2812 RGB, PMW3610 트랙볼)는 판매자 저장소
  [Vzhao-L/zmk-for-charybdis](https://github.com/Vzhao-L/zmk-for-charybdis)의 `main-20250226` 브랜치 기준.
- 키맵은 [ezaurum/Adv360-Pro-ZMK](https://github.com/ezaurum/Adv360-Pro-ZMK)(Kinesis Advantage360)
  배열을 Charybdis 56키에 맞게 이식한 것.

## 키맵

![Charybdis Keymap](img/charybdis.svg)

엄지 클러스터 (Adv360과 동일 기하학 — BSPC·DEL 왼손, ENTER·SPACE 오른손):

```
        왼쪽 엄지                        오른쪽 엄지
[HOME(홀드=스크롤)] [BSPC] [DEL]    [ENTER] [SPACE]
         [Fn] [Ctrl]                    [Win]
```

홈로우 모드(GACS): A=GUI, S=ALT, D=CTRL, F=SHIFT / J=SHIFT, K=CTRL, L=ALT, `;`=GUI (홀드 시).

| 레이어 | 진입 | 내용 |
|---|---|---|
| Base | 기본 | Adv360식 배열: `=`/`-` 숫자열, A 왼쪽 ESC, 하단 Shift, 홈로우 모드 |
| Nav | 왼엄지 HOME 홀드 (`lt 1`) | 화살표·Home/End/PgUp/PgDn·`[` `]`·CapsLock, **트랙볼이 스크롤 모드로 전환**, 마우스 클릭 |
| Fn | 왼엄지 아래 Fn 홀드 (`mo 2`) | F1–F12, **`Fn+A~G`=블루투스 프로파일 0~4**, `Fn+B`=현재 프로파일 페어링 해제, `Fn+Enter`=숫자패드 토글, `Fn+Space`=Mod 레이어 |
| Mod | Fn+Space 홀드 | 부트로더, ZMK Studio 언락, RGB 제어, 리셋, BT 예비 키 |
| Kp | Fn+Enter 토글 | 오른손 숫자패드 (Adv360 Keypad 레이어와 동일 배치) |
| Mouse | **트랙볼 움직이면 자동** | 엄지 키가 마우스 버튼으로 전환 (좌·우·휠클릭). 멈추면 400ms 후 원복 |

트랙볼: 기본은 커서 이동, 움직이면 Mouse 레이어 자동 활성화(`automouse-layer`),
Nav 홀드 중에는 스크롤 (`scroll-layers = <1>`).
왼손 엔코더: 1번 상하 스크롤, 2번 좌우 스크롤.

## 수정 방법

1. **ZMK Studio (실시간, 플래싱 불필요)** — [zmk.studio](https://zmk.studio/)를 크롬 계열
   브라우저에서 열고 USB로 연결하면 즉시 키맵을 바꿀 수 있다 (잠금 해제 불필요, `LOCKING=n`).
2. **소스 수정 후 재빌드** — `config/charybdis.keymap` 수정 후 아래 로컬 빌드.

## 로컬 빌드 (Docker)

GitHub Actions 없이 로컬에서 빌드한다:

```sh
./build.sh
```

- 첫 실행은 `west update` 때문에 수 분 걸린다 (워크스페이스는 `~/zmk-workspace`에 캐시됨).
- 결과물: `firmware/charybdis_left.uf2`, `firmware/charybdis_right.uf2`
  (오른쪽에는 ZMK Studio 스니펫 포함).

## 플래싱

1. 한쪽 하프를 USB로 연결하고 리셋 버튼을 **두 번** 눌러 부트로더 진입 (USB 드라이브로 마운트됨).
2. 해당 하프의 `.uf2` 파일을 드라이브에 복사하면 자동으로 플래싱 후 재부팅.
3. 좌우는 독립적이므로 각각 연결해서 플래싱한다.

> 키맵만 바꿀 때는 좌우 모두 플래싱할 필요 없이 **오른쪽(central, 트랙볼 쪽)** 만 플래싱해도 된다.
> 설정(`.conf`)이나 하드웨어 정의를 바꿨다면 양쪽 모두 플래싱.
> ZMK Studio도 central인 오른쪽에 USB로 연결한다.

## 키맵 다이어그램 갱신

[keymap-drawer](https://github.com/caksoylar/keymap-drawer)로 그린다. 로컬에서:

```sh
pip install keymap-drawer
keymap -c keymap_drawer.config.yaml parse -z config/charybdis.keymap > /tmp/parsed.yaml
keymap -c keymap_drawer.config.yaml draw --dts-layout config/boards/shields/charybdis/charybdis.dtsi /tmp/parsed.yaml > img/charybdis.svg
```

GitHub Actions를 활성화하면 `.github/workflows/draw-keymaps.yml`이 키맵 커밋 시 자동으로 갱신한다.

## 계보

- [eigatech/zmk-config](https://github.com/eigatech/zmk-config) — 최초 원본 (2022)
- [HeeTuic/zmk-for-charybdis](https://github.com/HeeTuic/zmk-for-charybdis) — ZMK Studio 지원, keymap-drawer, 문서화
- [Vzhao-L/zmk-for-charybdis](https://github.com/Vzhao-L/zmk-for-charybdis) — 실제 판매 하드웨어(XI-MK1_2) 대응: 핀맵, 엔코더, RGB
- 이 저장소 — Vzhao-L 기반 + HeeTuic의 keymap-drawer/배터리 프록시/트랙볼 절전 이식 + Adv360 키맵

베이스 펌웨어: [ZMK v0.3](https://github.com/zmkfirmware/zmk) + [zmk-pmw3610-driver](https://github.com/DoctorWangWang/zmk-pmw3610-driver)
