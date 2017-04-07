<article>
    <div class="header clearfix">
        <nav>
            <ul class="nav nav-pills float-right">
                <li class="nav-item">
                    <a class="nav-link" href="#" onclick="{ add }">Add</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#" onclick="{ reload }">Refresh</a>
                </li>
            </ul>
        </nav>
        <h3 class="text-muted">Articles</h3>
    </div>
    <div if="{ isLoading }">Loading...</div>
    <div if="{ isForm }">
        <form onsubmit="{ save }">
            <input type="hidden" class="form-control" ref="id">
            <div class="form-group row { has-danger: errors && errors.title }">
                <label for="title" class="col-sm-2 col-form-label">Title</label>
                <div class="col-sm-10">
                    <input type="text" class="form-control" ref="title" placeholder="Title">
                    <div if="{ errors && errors.title }" class="form-control-feedback">{ errors.title[0] }</div>
                </div>
            </div>
            <div class="form-group row { has-danger: errors && errors.content }">
                <label for="content" class="col-sm-2 col-form-label">Content</label>
                <div class="col-sm-10">
                    <textarea class="form-control" ref="content" placeholder="Content" rows="5"></textarea>
                    <div if="{ errors && errors.content }" class="form-control-feedback">{ errors.content[0] }</div>
                </div>
            </div>
            <div class="form-group row">
                <div class="offset-sm-2 col-sm-10">
                    <button type="submit" class="btn btn-outline-primary">{ isLoading ? 'Wait...':'Save' }</button>
                    <button type="button" class="btn btn-outline-primary" onclick="{ cancel }">Cancel</button>
                </div>
            </div>
        </form>
    </div>
    <div if="{ !isForm && !isLoading }">
        <div class="card mb-3" each="{ articles }">
            <div class="card-block">
                <h4 class="card-title">{ title }</h4>
                <h6 class="card-subtitle mb-2 text-muted">{ created_at }</h6>
                <p class="card-text">{ content }</p>
                <a href="#" class="card-link" onclick="{ edit }">Edit</a>
                <a href="#" class="card-link" onclick="{ delete }">Delete</a>
            </div>
        </div>
    </div>
    <script>
    this.api = 'https://rest-api.r10.co/articles';
    this.articles = [];
    this.isForm = false;
    this.errors = null;
    this.isLoading = true;

    this.add = (e) => {
        e.preventDefault();
        this.isForm = true;
    }

    this.cancel = (e) => {
        e.preventDefault();
        this.isForm = false;
        this.refs.id.value = '';
        this.refs.title.value = '';
        this.refs.content.value = '';
        this.errors = null;
    }

    this.edit = (e) => {
        e.preventDefault();
        this.update({
            isForm: true
        });
        this.refs.id.value = e.item.id;
        this.refs.title.value = e.item.title;
        this.refs.content.value = e.item.content;
    }

    this.save = (e) => {
        e.preventDefault();
        if (this.isLoading) {
            return false;
        }

        this.isLoading = true;
        let id = this.refs.id.value;

        $.ajax({
            url: id != '' ? this.api + '/' + id : this.api,
            type: id != '' ? 'PUT' : 'POST',
            data: {
                title: this.refs.title.value,
                content: this.refs.content.value,
            },
            success: (response) => {
                this.refs.id.value = '';
                this.refs.title.value = '';
                this.refs.content.value = '';

                this.update({
                    isForm: false,
                    errors: null,
                    isLoading: false
                });

                this.refresh();
            },
            error: (response) => {
                let data = response.responseJSON;

                if (data && data.message) {
                    //alert(data.message);
                }

                if (data && data.errors) {
                    this.errors = data.errors;
                }

                this.update({
                    isLoading: false
                });
            }
        });
    }

    this.delete = (e) => {
        e.preventDefault();

        $.ajax({
            url: this.api + '/' + e.item.id,
            type: 'DELETE',
            success: (response) => {
                this.refresh();
            }
        });
    }

    this.refresh = () => {
        this.isLoading = true;

        $.ajax({
            url: this.api,
            success: (response) => {
                this.update({
                    articles: response.data,
                    isLoading: false
                });
            }
        });
    }

    this.reload = (e) => {
        e.preventDefault();
        this.refresh();
    }

    this.on('mount', () => {
        this.refresh();
    })
    </script>
</article>
