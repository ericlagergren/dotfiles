#include <iostream>
#include <string>
#include <git2.h>

// g++ -std=c++17 -O3 
//     -Wall -Werror -Wextra -pedantic \
//     xxx.cpp $(pkg-config --libs libgit2)

#ifdef DEBUG
bool check(int err, const char *message, const char *extra) {
	if (!err) { return false; }
	const git_error *error;
	const char *msg = "", *spacer = "";
	if ((error = giterr_last()) != NULL && error->message != NULL) {
		msg = error->message;
		spacer = " - ";
	}
	if (extra) {
		fprintf(stderr, "%s '%s' [%d]%s%s\n", message, extra, err, spacer, msg);
	} else {
		fprintf(stderr, "%s [%d]%s%s\n", message, err, spacer, msg);
	}
	return true;
}

template<size_t N>
constexpr size_t length(char const (&)[N]) { return N-1; }

void set_string(std::string &str, unsigned int flags) {
	if (flags == GIT_STATUS_CURRENT) {
		str += "current";
		return;
	}
	for (unsigned int i = 1; flags != 0; i <<= 1) {
		if ((flags & i) == 0) { continue; }
		switch (flags ^= i; i) {
		case GIT_STATUS_INDEX_NEW:        str += "new | ";           break;
		case GIT_STATUS_INDEX_MODIFIED:   str += "modified | ";      break;
		case GIT_STATUS_INDEX_DELETED:    str += "deleted | ";       break;
		case GIT_STATUS_INDEX_RENAMED:    str += "renamed | ";       break;
		case GIT_STATUS_INDEX_TYPECHANGE: str += "typechange | ";    break;
		case GIT_STATUS_WT_NEW:           str += "wt_new | ";        break;
		case GIT_STATUS_WT_MODIFIED:      str += "wt_modified | ";   break;
		case GIT_STATUS_WT_DELETED:       str += "wt_deleted | ";    break;
		case GIT_STATUS_WT_TYPECHANGE:    str += "wt_typechange | "; break;
		case GIT_STATUS_WT_RENAMED:       str += "wt_renamed | ";    break;
		case GIT_STATUS_WT_UNREADABLE:    str += "wt_unreadable | "; break;
		case GIT_STATUS_IGNORED:          str += "ignored | ";       break;
		case GIT_STATUS_CONFLICTED:       str += "conflicted | ";    break;
		}
	}

	constexpr int len = length(" | ");
	for (int i = 0; i < len; ++i) {
		str.pop_back();
	}
}
#endif // DEBUG

#define CLEAN    (1u << 0)
#define ADDED    (1u << 1)
#define DIRTY    (1u << 2)
#define CONFLICT (1u << 3)

int status_cb(const char* path, unsigned int flags, void* payload) {
#ifdef DEBUG
	std::string str;
	set_string(str, flags);
	printf("%s -> %s\n", path, str.c_str());
#else
	(void)(path);
#endif // DEBUG

	unsigned int* s = (unsigned int*)(payload);
	if ((flags & GIT_STATUS_CONFLICTED) != 0) {
		*s = CONFLICT;
		return 1;
	}

	const auto dirty = GIT_STATUS_WT_MODIFIED   |
					   GIT_STATUS_WT_NEW        |
					   GIT_STATUS_WT_DELETED    |
					   GIT_STATUS_WT_TYPECHANGE |
					   GIT_STATUS_WT_RENAMED;
	if ((flags & dirty) != 0) {
		*s = DIRTY;
		return 1;
	}

	const auto added = GIT_STATUS_INDEX_NEW        |
				  	   GIT_STATUS_INDEX_MODIFIED   |
					   GIT_STATUS_INDEX_DELETED    |
					   GIT_STATUS_INDEX_TYPECHANGE;
	if ((flags & added) != 0) {
		*s |= ADDED;
		return 0;
	}
	return 0;
}

#define COLOR(x) "\\[\x1b[" x "\\]"

#define RESET  COLOR("0m")
#define RED    COLOR("31m")
#define GREEN  COLOR("32m")
#define YELLOW COLOR("33m")
#define WHITE  COLOR("37m")
#define BLUE   COLOR("38;5;153m")

#define LIT(color, lit) color lit RESET

#define    RED_LIT(lit) LIT(RED,    lit)
#define  GREEN_LIT(lit) LIT(GREEN,  lit)
#define YELLOW_LIT(lit) LIT(YELLOW, lit)
#define  WHITE_LIT(lit) LIT(WHITE,  lit)
#define   BLUE_LIT(lit) LIT(BLUE,   lit)

#define VAR(buf, color, var) \
	do {                     \
		(buf) += (color);    \
		(buf) += (var);      \
		(buf) += RESET;      \
	} while(0);

#define    RED_VAR(buf, var) VAR(buf,    RED, var)
#define  GREEN_VAR(buf, var) VAR(buf,  GREEN, var)
#define YELLOW_VAR(buf, var) VAR(buf, YELLOW, var)
#define  WHITE_VAR(buf, var) VAR(buf,  WHITE, var)
#define   BLUE_VAR(buf, var) VAR(buf,   BLUE, var)

void handle_git(std::string &buf) {
	git_reference* ref = nullptr;
	git_status_options opts;
	unsigned int flags = 0;

	git_libgit2_init();
	git_repository *repo = nullptr;
	if (git_repository_open_ext(&repo, ".", 0, nullptr)) {
		git_libgit2_shutdown();
		return;
	}

	buf += WHITE_LIT("[");

	switch (git_repository_head(&ref, repo)) {
	case 0:
		BLUE_VAR(buf, git_reference_shorthand(ref));
		break;
	case GIT_EUNBORNBRANCH:
		buf += RED_LIT("<unborn>");
		break;
	case GIT_ENOTFOUND:
		buf += RED_LIT("<not found>");
		break;
	default:
		goto cleanup;
	}

	buf += WHITE_LIT(": ");

	if (git_status_init_options(&opts, GIT_STATUS_OPTIONS_VERSION)) {
		buf += RED_LIT("???");
		goto cleanup;
	}
	opts.show  = GIT_STATUS_SHOW_INDEX_AND_WORKDIR;
	opts.flags = GIT_STATUS_OPT_INCLUDE_UNTRACKED |
				 GIT_STATUS_OPT_EXCLUDE_SUBMODULES;

	git_status_foreach_ext(repo, &opts, status_cb, &flags);
	if (flags & CONFLICT) {
		buf += RED_LIT("CONFLICT");
	} else if (flags & DIRTY) {
		buf += RED_LIT("DIRTY");
	} else if (flags & ADDED) {
		buf += YELLOW_LIT("ADDED");
	} else {
		buf += GREEN_LIT("CLEAN");
	}

cleanup:
	if (ref) { git_reference_free(ref); }
	git_repository_free(repo);
	git_libgit2_shutdown();
	
	buf += WHITE_LIT("] ");
}

int main(int argc, const char** argv) {
	#define EXISTS(x) (argc >= (x)+1 && argv[(x)][0])
	#define RET     1 // $?
	#define SHLVL   2 // $SHLVL
	#define SSH_TTY 3 // $SSH_TTY

	std::string buf;
	if (EXISTS(RET)) {
		const char* ret = argv[1];
		if (ret[0] == '0' && !ret[1]) {
			buf += GREEN_LIT("0");
		} else {
			RED_VAR(buf, ret);
		}
	} else {
		buf += YELLOW_LIT("?");
	}

	buf += WHITE_LIT(":");

	if (EXISTS(SHLVL)) {
		BLUE_VAR(buf, std::to_string(std::stoi(argv[2]) - 1));
		buf += ' ';
	} else {
		buf += BLUE_LIT("? ");
	}

	if (EXISTS(SSH_TTY)) {
		buf += WHITE_LIT("@");
		WHITE_VAR(buf, std::getenv("HOSTNAME"));
	}
	buf += WHITE_LIT("\\w ");

	handle_git(buf);

	buf += BLUE_LIT("\\$ ");

	fputs(buf.c_str(), stdout);
	return 0;
}

