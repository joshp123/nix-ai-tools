runHook preInstall

package_dir="$out/share/pi/packages/$piPackageName"
install -d "$package_dir"
tar -xzf "$src" --strip-components=1 -C "$package_dir"

actual_version=$("$runtimeNode/bin/node" -p \
  "require('$package_dir/package.json').version")
if [ "$actual_version" != "$version" ]; then
  echo "error: $pname declares version $version but contains $actual_version" >&2
  exit 1
fi

# The lockfile must cover exactly the dependencies this version declares.
"$runtimeNode/bin/node" -e '
  const sorted = (o) => JSON.stringify(Object.fromEntries(Object.entries(o ?? {}).sort()));
  const declared = sorted(require(process.argv[1]).dependencies);
  const locked = sorted(JSON.parse(process.argv[2]));
  if (declared !== locked) {
    console.error(`error: ${process.env.pname} declares dependencies ${declared} but its lockfile has ${locked}; run scripts/pi-package-lock.sh ${process.env.pname}`);
    process.exit(1);
  }
' "$package_dir/package.json" "$piNpmDependencies"

install -d "$package_dir/node_modules"
if [ -n "$piNpmDeps" ]; then
  deps_dir="$TMPDIR/npm-deps"
  install -d "$deps_dir"
  cp "$piNpmDeps/package.json" "$piNpmDeps/package-lock.json" "$deps_dir/"
  (cd "$deps_dir" && HOME="$TMPDIR" npm ci --offline --ignore-scripts \
    --legacy-peer-deps --no-audit --no-fund)
  cp -R "$deps_dir/node_modules/." "$package_dir/node_modules/"
  rm -rf "$package_dir/node_modules/.bin" "$package_dir/node_modules/.package-lock.json"
fi

# Pi packages declare these as peers, but their immutable package roots are
# outside Pi's own node_modules tree. Link the already-packaged peers instead
# of installing a second copy.
ln -s "$piPeerNodeModules/@earendil-works" "$package_dir/node_modules/@earendil-works"
ln -s "$piPeerNodeModules/typebox" "$package_dir/node_modules/typebox"

for entry in $binEntries; do
  name="${entry%%:*}"
  script="${entry#*:}"
  makeWrapper "$runtimeNode/bin/node" "$out/bin/$name" \
    --add-flags "$package_dir/$script"
done

runHook postInstall
