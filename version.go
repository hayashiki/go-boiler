package goboiler

var (
	version  = "0.0.3"
	revision = "HEAD"
)

func Version() string {
	return version
}

func Revision() string {
	return revision
}
