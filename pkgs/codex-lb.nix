{ fetchPypi
, lib
, makeWrapper
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "codex-lb";
  version = "1.15.0";
  format = "wheel";

  src = fetchPypi {
    pname = "codex_lb";
    inherit version format;
    dist = "py3";
    python = "py3";
    hash = "sha256-FLp9IQWDZLGWbcefn1fhSFYOICm9lkwNI+j9lVqgbPY=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  propagatedBuildInputs = with python3Packages; [
    aiohttp
    aiohttp-retry
    aiosqlite
    alembic
    asyncpg
    bcrypt
    brotli
    cryptography
    fastapi
    greenlet
    httptools
    psycopg
    pydantic
    pydantic-settings
    pyotp
    python-dotenv
    python-multipart
    segno
    sqlalchemy
    starlette
    uvicorn
    uvloop
    watchfiles
    websockets
    zstandard
  ];

  pythonImportsCheck = [ "app.main" "app.cli" ];

  postInstall = ''
    wrapProgram "$out/bin/codex-lb" \
      --set-default CODEX_LB_DATABASE_MIGRATE_ON_STARTUP true
  '';

  doCheck = false;

  meta = with lib; {
    description = "Codex load balancer and proxy for ChatGPT accounts with usage dashboard";
    homepage = "https://github.com/Soju06/codex-lb";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "codex-lb";
  };
}
