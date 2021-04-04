DOMAIN=blog.nicro.land

gitignore:
	grep -q -F '^public$$' .gitignore || echo 'public' >> .gitignore

init: gitignore
	git checkout --orphan gh-pages
	git reset --hard
	git commit --allow-empty -m "Initialising gh-pages branch"
	git push origin gh-pages
	git checkout master
	git worktree add -B gh-pages public origin/gh-pages

public:
	git worktree add -B gh-pages public origin/gh-pages

_clean:
	git worktree remove public --force

clean: _clean public

update:
	hugo

.PHONY: gitignore init _clean clean update
