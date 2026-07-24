runHook preInstall

package_dir="$out/share/pi/packages/$piPackageName"
install -d "$package_dir"
tar -xzf "$src" --strip-components=1 -C "$package_dir"

actual_version=$("$nodejs_22/bin/node" -p \
  "require('$package_dir/package.json').version")
if [ "$actual_version" != "$version" ]; then
  echo "error: $pname declares version $version but contains $actual_version" >&2
  exit 1
fi

# Pi packages declare these as peers, but their immutable package roots are
# outside Pi's own node_modules tree. Link the already-packaged peers instead
# of running npm during a build or at activation time.
install -d "$package_dir/node_modules"
ln -s "$piPeerNodeModules/@earendil-works" "$package_dir/node_modules/@earendil-works"
ln -s "$piPeerNodeModules/typebox" "$package_dir/node_modules/typebox"

for entry in $binEntries; do
  name="${entry%%:*}"
  script="${entry#*:}"
  makeWrapper "$nodejs_22/bin/node" "$out/bin/$name" \
    --add-flags "$package_dir/$script"
done

runHook postInstall
