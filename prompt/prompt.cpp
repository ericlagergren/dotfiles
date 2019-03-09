#include <git2.h>
#include <iostream>
#include <string>

#ifdef DEBUG
bool check(int err, const char *message, const char *extra) {
	if (!err) {
		return false;
	}

	const git_error *error;
	const char *     msg = "", *spacer = "";
	if ((error = giterr_last()) != NULL && error->message != NULL) {
		msg    = error->message;
		spacer = " - ";
	}
	if (extra) {
		fprintf(stderr, "%s '%s' [%d]%s%s\n", message, extra, err, spacer, msg);
	} else {
		fprintf(stderr, "%s [%d]%s%s\n", message, err, spacer, msg);
	}
	return true;
}

template <size_t N>
constexpr size_t length(char const (&)[N]) {
	return N - 1;
}

void set_string(std::string &str, unsigned int flags) {
	if (flags == GIT_STATUS_CURRENT) {
		str += "current";
		return;
	}
	for (unsigned int i = 1; flags != 0; i <<= 1) {
		if ((flags & i) == 0) {
			continue;
		}
		switch (flags ^= i; i) {
		case GIT_STATUS_INDEX_NEW:
			str += "new | ";
			break;
		case GIT_STATUS_INDEX_MODIFIED:
			str += "modified | ";
			break;
		case GIT_STATUS_INDEX_DELETED:
			str += "deleted | ";
			break;
		case GIT_STATUS_INDEX_RENAMED:
			str += "renamed | ";
			break;
		case GIT_STATUS_INDEX_TYPECHANGE:
			str += "typechange | ";
			break;
		case GIT_STATUS_WT_NEW:
			str += "wt_new | ";
			break;
		case GIT_STATUS_WT_MODIFIED:
			str += "wt_modified | ";
			break;
		case GIT_STATUS_WT_DELETED:
			str += "wt_deleted | ";
			break;
		case GIT_STATUS_WT_TYPECHANGE:
			str += "wt_typechange | ";
			break;
		case GIT_STATUS_WT_RENAMED:
			str += "wt_renamed | ";
			break;
		case GIT_STATUS_WT_UNREADABLE:
			str += "wt_unreadable | ";
			break;
		case GIT_STATUS_IGNORED:
			str += "ignored | ";
			break;
		case GIT_STATUS_CONFLICTED:
			str += "conflicted | ";
			break;
		}
	}

	constexpr int len = length(" | ");
	for (int i = 0; i < len; ++i) {
		str.pop_back();
	}
}
#endif // DEBUG

#define CLEAN (1u << 0)
#define ADDED (1u << 1)
#define DIRTY (1u << 2)
#define CONFLICT (1u << 3)

int status_cb(const char *path, unsigned int flags, void *payload) {
#ifdef DEBUG
	std::string str;
	set_string(str, flags);
	printf("%s -> %s\n", path, str.c_str());
#else
	(void)(path);
#endif // DEBUG

	unsigned int *s = (unsigned int *)(payload);
	if ((flags & GIT_STATUS_CONFLICTED) != 0) {
		*s = CONFLICT;
		return 1;
	}

	const auto dirty = GIT_STATUS_WT_MODIFIED | GIT_STATUS_WT_NEW
	                   | GIT_STATUS_WT_DELETED | GIT_STATUS_WT_TYPECHANGE
	                   | GIT_STATUS_WT_RENAMED;
	if ((flags & dirty) != 0) {
		*s = DIRTY;
		return 1;
	}

	const auto added = GIT_STATUS_INDEX_NEW | GIT_STATUS_INDEX_MODIFIED
	                   | GIT_STATUS_INDEX_DELETED | GIT_STATUS_INDEX_TYPECHANGE;
	if ((flags & added) != 0) {
		*s |= ADDED;
		return 0;
	}
	return 0;
}

#define COLOR(x) "\\[\x1b[" x "\\]"

template <typename T>
void append(std::string &buf, T &&t) {
	buf += t;
}
template <typename T, typename... Ts>
void append(std::string &buf, T &&t, Ts &&... ts) {
	buf += t;
	append(buf, ts...);
}

#define MAKE_COLOR(name, color)                                                \
	template <typename T, typename... Ts>                                      \
	void append_##name(std::string &buf, T &&t, Ts &&... ts) {                 \
		buf += COLOR(color);                                                   \
		append(buf, t, ts...);                                                 \
		buf += COLOR("0m");                                                    \
	}

MAKE_COLOR(red, "31m");
MAKE_COLOR(green, "32m");
MAKE_COLOR(yellow, "33m");
MAKE_COLOR(white, "37m");
MAKE_COLOR(blue, "38;5;153m");

void handle_git(std::string &buf) {
	git_reference *    ref = nullptr;
	git_status_options opts;
	unsigned int       flags = 0;

	git_libgit2_init();
	git_repository *repo = nullptr;
	if (git_repository_open_ext(&repo, ".", 0, nullptr)) {
		git_libgit2_shutdown();
		return;
	}

	append_white(buf, "[");

	switch (git_repository_head(&ref, repo)) {
	case 0:
		append_blue(buf, git_reference_shorthand(ref));
		break;
	case GIT_EUNBORNBRANCH:
		append_red(buf, "<unborn>");
		break;
	case GIT_ENOTFOUND:
		append_red(buf, "<not found>");
		break;
	default:
		goto cleanup;
	}

	append_white(buf, ": ");

	if (git_status_init_options(&opts, GIT_STATUS_OPTIONS_VERSION)) {
		append_red(buf, "???");
		goto cleanup;
	}
	opts.show = GIT_STATUS_SHOW_INDEX_AND_WORKDIR;
	opts.flags
	    = GIT_STATUS_OPT_INCLUDE_UNTRACKED | GIT_STATUS_OPT_EXCLUDE_SUBMODULES;

	git_status_foreach_ext(repo, &opts, status_cb, &flags);
	if (flags & CONFLICT) {
		append_red(buf, "CONFLICT");
	} else if (flags & DIRTY) {
		append_red(buf, "DIRTY");
	} else if (flags & ADDED) {
		append_yellow(buf, "ADDED");
	} else {
		append_green(buf, "CLEAN");
	}

cleanup:
	if (ref) {
		git_reference_free(ref);
	}
	git_repository_free(repo);
	git_libgit2_shutdown();

	append_white(buf, "] ");
}

int main(int argc, const char **argv) {
#define EXISTS(x) (argc >= (x) + 1 && argv[(x)][0])
#define RET 1     // $?
#define SHLVL 2   // $SHLVL
#define SSH_TTY 3 // $SSH_TTY

	std::string buf;
	if (EXISTS(RET)) {
		const char *ret = argv[1];
		if (ret[0] == '0' && !ret[1]) {
			append_green(buf, "0");
		} else {
			append_red(buf, ret);
		}
	} else {
		append_yellow(buf, "?");
	}

	append_white(buf, ":");

	if (EXISTS(SHLVL)) {
		append_blue(buf, std::to_string(std::stoi(argv[2]) - 1), ' ');
	} else {
		append_blue(buf, "? ");
	}

	if (EXISTS(SSH_TTY)) {
		append_white(buf, "@", std::getenv("HOSTNAME"));
	}
	append_white(buf, "\\w ");

	handle_git(buf);

	append_blue(buf, "\\$ ");

	fputs(buf.c_str(), stdout);
	return 0;
}
