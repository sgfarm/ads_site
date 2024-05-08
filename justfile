
serve:
    mdbook serve
container:
	nix build "./#container" && docker load -i result && docker run --rm -p 3000:3000 ads-book-server
