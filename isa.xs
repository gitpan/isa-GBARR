#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#if !defined(XS_VERSION) && defined(VERSION)
 #define XS_VERSION VERSION
#endif

#ifdef XS_VERSION
# define XS_VERSION_BOOTCHECK \
    do {                                                                        \
        char vn[255], *module = SvPV(ST(0),na);                                 \
        if (items >= 2)         /* version supplied as bootstrap arg */         \
            Sv=ST(1);                                                           \
        else {                  /* read version from module::VERSION */         \
            sprintf(vn,"%s::VERSION", module);                                  \
            Sv = perl_get_sv(vn, GV_ADD);   /* XXX GV_ADDWARN */                \
        }                                                                       \
        if (Sv && (!SvOK(Sv) || strNE(XS_VERSION, SvPV(Sv,na))) )               \
            croak("%s object version %s does not match %s.pm $VERSION %s",      \
              module,XS_VERSION, module,(Sv && SvOK(Sv))?SvPV(Sv,na):"(undef)");\
    } while (0)
#else
# define XS_VERSION_BOOTCHECK
#endif


/*
 * The main guts of traverse_isa was actually copied from gv_fetchmeth
 */

static SV *
isa_lookup(stash, name, len, level)
HV *stash;
char *name;
int len;
int level;
{
    AV* av;
    GV* gv;
    GV** gvp;
    HV* hv = Nullhv;

    if (!stash)
	return &sv_undef;

    if(strEQ(HvNAME(stash), name))
	return &sv_yes;

    if (level > 100)
	croak("Recursive inheritance detected");

    gvp = (GV**)hv_fetch(stash, "::ISA::CACHE::", 14, FALSE);

    if (gvp && (gv = *gvp) != (GV*)&sv_undef && (hv = GvHV(gv))) {
	SV* sv;
	SV** svp = (SV**)hv_fetch(hv, name, len, FALSE);
	if (svp && (sv = *svp) != (SV*)&sv_undef)
	    return sv;
    }

    gvp = (GV**)hv_fetch(stash,"ISA",3,FALSE);
    
    if (gvp && (gv = *gvp) != (GV*)&sv_undef && (av = GvAV(gv))) {
	if(!hv) {
	    gvp = (GV**)hv_fetch(stash, "::ISA::CACHE::", 14, TRUE);

	    gv = *gvp;

	    if (SvTYPE(gv) != SVt_PVGV)
		gv_init(gv, stash, "::ISA::CACHE::", 14, TRUE);

	    hv = GvHVn(gv);
	}
	if(hv) {
	    SV** svp = AvARRAY(av);
	    I32 items = AvFILL(av) + 1;
	    while (items--) {
		SV* sv = *svp++;
		HV* basestash = gv_stashsv(sv, FALSE);
		if (!basestash) {
		    if (dowarn)
			warn("Can't locate package %s for @%s::ISA",
			    SvPVX(sv), HvNAME(stash));
		    continue;
		}
		if(&sv_yes == isa_lookup(basestash, name, len, level + 1)) {
		    (void)hv_store(hv,name,len,&sv_yes,0);
		    return &sv_yes;
		}
	    }
	    (void)hv_store(hv,name,len,&sv_no,0);
	}
    }

    return &sv_no;
}

MODULE = isa		PACKAGE = UNIVERSAL

SV *
isa(sv, name)
SV *sv
char *name
CODE:
{

    if (!SvROK(sv)) {
	ST(0) = &sv_no;
	return;
    }

    sv = (SV*)SvRV(sv);

    if(SvOBJECT(sv) &&
       &sv_yes == isa_lookup(SvSTASH(sv), name, strlen(name), 0)) {
	ST(0) = &sv_yes;
	return;
    }

    switch (SvTYPE(sv)) {
    case SVt_PVAV:
	if(strEQ("ARRAY",name)) {
	    ST(0) = &sv_yes;
	    return;
	}
	break;
    case SVt_PVHV:
	if(strEQ("HASH",name)) {
	    ST(0) = &sv_yes;
	    return;
	}
	break;
    case SVt_PVCV:
	if(strEQ("CODE",name)) {
	    ST(0) = &sv_yes;
	    return;
	}
	break;
    case SVt_PVGV:
	if(strEQ("GLOB",name)) {
	    ST(0) = &sv_yes;
	    return;
	}
	break;
    default:
	if(strEQ("SCALAR",name)) {
	    ST(0) = &sv_yes;
	    return;
	}
    }

    ST(0) = &sv_no;
}

SV *
can(sv, name)
SV *sv
char *name
CODE:
{
    GV *gv;
    SV* rv = &sv_undef;
    CV *cv;

    if (!SvROK(sv)) {
       ST(0) = &sv_undef;
       return;
    }

    sv = (SV*)SvRV(sv);

    if(!SvOBJECT(sv)) {
       ST(0) = &sv_undef;
       return;
    }


    gv = gv_fetchmethod(SvSTASH(sv), name);

    if(gv && (cv = GvCV(gv))) {
	rv = sv_newmortal();
	sv_setsv(rv, newRV((SV*)cv));
    }
    ST(0) = rv;
}

BOOT:
 XS_VERSION_BOOTCHECK;

