runHook preInstall

package_dir="$out/share/pi/packages/$piPackageName"
install -d "$package_dir"
tar -xzf "$src" --strip-components=1 -C "$package_dir"

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
