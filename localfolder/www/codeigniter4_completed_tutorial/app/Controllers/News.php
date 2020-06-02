<?php namespace App\Controllers;

use App\Models\NewsModel;
use CodeIgniter\Controller;

class News extends Controller
{
    public function index()
    {
        $model = new NewsModel();

        $data = [
            'news'  => $model->getNews(),
            'title' => 'News archive',
        ];

        echo view('templates/header', $data);
        echo view('news/overview', $data);
        echo view('templates/footer', $data);
    }

    public function view($slug = null)
    {
        $model = new NewsModel();

        $data['news'] = $model->getNews($slug);

        if (empty($data['news']))
        {
            throw new \CodeIgniter\Exceptions\PageNotFoundException('Cannot find the news item: '. $slug);
        }

        $data['title'] = $data['news']['title'];

        echo view('templates/header', $data);
        echo view('news/view', $data);
        echo view('templates/footer', $data);
    }

    public function create()
    {
        $model = new NewsModel();
        log_message('debug', __CLASS__ . '::' . __FUNCTION__  . ' - start ');
        if (! $this->validate([
            'title' => 'required|min_length[3]|max_length[255]',
            'body'  => 'required'
        ]))
        {
            echo view('templates/header', ['title' => 'Create a news item']);
            echo view('news/create');
            echo view('templates/footer');
            log_message('debug', __CLASS__ . '::' . __FUNCTION__  .' - ! $this->validate ');
        }
        else
        {
            $model->save([
                'title' => $this->request->getVar('title'),
                'slug'  => url_title($this->request->getVar('title'), '-', TRUE),
                'body'  => $this->request->getVar('body'),
            ]);

            echo view('news/success');
            log_message('debug', __CLASS__ . '::' . __FUNCTION__ . ' - saved ');
        }

        log_message('debug', __CLASS__ . '::' . __FUNCTION__ . ' - end ');
    }
}