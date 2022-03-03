package goboiler

var (
	version  = "0.0.2"
	revision = "HEAD"
)

func Version() string {
	return version
}

func Revision() string {
	return revision
}
