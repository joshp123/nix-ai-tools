{ fetchurl
, lib
, makeWrapper
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "codex-lb";
  version = "1.10.1";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/18/47/bf8a5fa7d129901606cf8e53901cdade750b2a475f61d313050814346588/codex_lb-1.10.1-py3-none-any.whl";
    hash = "sha256-9ttVfZ/e6fbQFigHveON7A09EI0J6ZyJjMkaAjXJB0c=";
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
