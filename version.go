package goboiler

var (
	version  = "0.0.4"
	revision = "HEAD"
)

func Version() string {
	return version
}

func Revision() string {
	return revision
}
