package git

import (
	"fmt"
	"net/http"

	"gitlab.com/gitlab-org/gitaly/v16/proto/go/gitalypb"

	"gitlab.com/gitlab-org/gitlab/workhorse/internal/api"
	"gitlab.com/gitlab-org/gitlab/workhorse/internal/gitaly"
	"gitlab.com/gitlab-org/gitlab/workhorse/internal/helper/fail"
	"gitlab.com/gitlab-org/gitlab/workhorse/internal/senddata"
)

type blob struct{ senddata.Prefix }
type blobParams struct {
	GitalyServer   api.GitalyServer
	GetBlobRequest gitalypb.GetBlobRequest
}

var SendBlob = &blob{"git-blob:"}

func (b *blob) Inject(w http.ResponseWriter, r *http.Request, sendData string) {
	var params blobParams
	if err := b.Unpack(&params, sendData); err != nil {
		fail.Request(w, r, fmt.Errorf("SendBlob: unpack sendData: %v", err))
		return
	}

	ctx, blobClient, err := gitaly.NewBlobClient(r.Context(), params.GitalyServer)

	if err != nil {
		fail.Request(w, r, fmt.Errorf("blob.GetBlob: %v", err))
		return
	}

	setBlobHeaders(w)
	if err := blobClient.SendBlob(ctx, w, &params.GetBlobRequest); err != nil {
		fail.Request(w, r, fmt.Errorf("blob.GetBlob: %v", err))
		return
	}
}

func setBlobHeaders(w http.ResponseWriter) {
	// Caching proxies usually don't cache responses with Set-Cookie header
	// present because it implies user-specific data, which is not the case
	// for blobs.
	w.Header().Del("Set-Cookie")
}
